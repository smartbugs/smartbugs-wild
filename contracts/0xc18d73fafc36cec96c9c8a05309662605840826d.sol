pragma solidity 0.4.25;

/* ETH7.IO - MADE FOR PEOPLE
* ETHEREUM ACCUMULATIVE SMARTCONTRACT
* Web  - https://eth7.io
* - GAIN 1.85% OF YOUR DEPOSIT  PER 12 HOURS (3.7% PER DAY)
* - A UNIQUE SYSTEM DAYS OF CASHBACK DEVELOPED BY A TEAM ETH7
* - Affiliate program 4% from each Deposit Of your partner 
* - Minimal contribution is 0.01 eth
* - Currency and payment – ETH
* - Transfer funds only from Your personal ETH wallet
* - Contribution allocation schemes:
*    -- 89% payments
*    -- 11% Marketing + Operating Expenses

* ---How to use:
*  1. Send from ETH wallet to the smart contract address "0xC18D73FAfc36cEc96c9C8a05309662605840826d"
*     any amount above 0.01 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
 of your wallet.
*   Claim your profit by sending 0 ether transaction 
* Get your profit every 12 hours by sending 0 ether transaction to  smart contract address
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* 
* The contract has passed several security audits and has been approved by professionals 
ETH7.IO - MADE FOR PEOPLE
*/

/**
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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor() internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

}

/**
The development of the contract is entirely owned by the ETH7 campaign, any copying of the source code is not legal.
*/
contract Eth7 is ReentrancyGuard {
    //use of library of safe mathematical operations    
    using SafeMath for uint;
    // array containing information about beneficiaries
    mapping(address => uint) public userDeposit;
    // array of refferels
    mapping(address => address) public userReferral;
    // collected from refferal system
    mapping(address => uint) public refferalCollected;
    // array containing information about users cashback
    mapping(address => uint) public usersCashback;
    //array containing information about the time of payment
    mapping(address => uint) public userTime;
    //array containing information on interest paid
    mapping(address => uint) public persentWithdraw;
    // users already deposited
    mapping(address => bool) public alreadyDeposited;
    //fund fo transfer marceting percent 
    address public marketingFund = 0xFEfF6b5811AEa737E03f526fD8C4E72924fdEA54;
    //wallet for a dev foundation
    address public devFund = 0x03e08ce26C93F6403C84365FF58498feA6c88A6a;
    //percentage deducted to the advertising fund
    uint marketingPercent = 8;
    //percent for a charitable foundation
    uint public devPercent = 3;
    // refferal percent
    uint public refPercent = 4;
    //time through which you can take dividends
    //uint public chargingTime = 12 hours;
    uint public chargingTime = 12 hours;
    
    //start persent 1.85% per 12 hours
    uint public persent = 1850;

    uint public countOfInvestors = 0;
    uint public countOfDev = 0;
    
    // information about cashback actions
    uint public minDepCashBackLevel1 = 100 finney;
    uint public maxDepCashBackLevel1 = 3 ether;
    uint public maxDepCashBackLevel2 = 7 ether;
    uint public maxDepCashBackLevel3 = 10000 ether;
    
    // 1st action
    uint public beginCashBackTime1 = 1541462399;     // begin of the action 05.11.2018 
    uint public endCashBackTime1 = 1541548799;       // end of the action 06.11.2018
    uint public cashbackPercent1level1 = 25;       // cashback persent 25 = 2.5%
    uint public cashbackPercent1level2 = 35;       // cashback persent 35 = 3.5%
    uint public cashbackPercent1level3 = 50;       // cashback persent 50 = 5%

    // 2 action
    uint public beginCashBackTime2 = 1542326399;     // begin of the action 15.11.2018
    uint public endCashBackTime2 = 1542499199;       // end of the action 17.11.2018
    uint public cashbackPercent2level1 = 30;       
    uint public cashbackPercent2level2 = 50;       
    uint public cashbackPercent2level3 = 70;       

    // 3 action
    uint public beginCashBackTime3 = 1543363199;     // begin of the action 27.11.2018 
    uint public endCashBackTime3 = 1543535999;       // end of the action 29.11.2018
    uint public cashbackPercent3level1 = 50;       
    uint public cashbackPercent3level2 = 80;       
    uint public cashbackPercent3level3 = 100;      

    // 4 action
    uint public beginCashBackTime4 = 1544399999;     // begin of the action 9.12.2018
    uint public endCashBackTime4 = 1544572799;       // end of the action 11.12.2018 
    uint public cashbackPercent4level1 = 70;       
    uint public cashbackPercent4level2 = 100;       
    uint public cashbackPercent4level3 = 150;      

    // 5 action
    uint public beginCashBackTime5 = 1545436799;     // begin of the action 21.12.2018
    uint public endCashBackTime5 = 1545523199;       // end of the action 22.12.2018 
    uint public cashbackPercent5level1 = 25;       
    uint public cashbackPercent5level2 = 35;       
    uint public cashbackPercent5level3 = 50;      

    // 6 action
    uint public beginCashBackTime6 = 1546473599;     // begin of the action 02.01.2019 
    uint public endCashBackTime6 = 1546646399;       // end of the action 04.01.2019
    uint public cashbackPercent6level1 = 30;       
    uint public cashbackPercent6level2 = 50;       
    uint public cashbackPercent6level3 = 70;      

    // 7 action
    uint public beginCashBackTime7 = 1547510399;     // begin of the action 14.01.2019
    uint public endCashBackTime7 = 1547683199;       // end of the action 16.01.2019
    uint public cashbackPercent7level1 = 50;       
    uint public cashbackPercent7level2 = 80;       
    uint public cashbackPercent7level3 = 100;      

    // 8 action
    uint public beginCashBackTime8 = 1548547199;     // begin of the action 26.01.2019
    uint public endCashBackTime8 = 1548719999;       // end of the action 28.01.2019
    uint public cashbackPercent8level1 = 70;       
    uint public cashbackPercent8level2 = 100;       
    uint public cashbackPercent8level3 = 150;      


    modifier isIssetUser() {
        require(userDeposit[msg.sender] > 0, "Deposit not found");
        _;
    }

    modifier timePayment() {
        require(now >= userTime[msg.sender].add(chargingTime), "Too fast payout request");
        _;
    }

    function() external payable {
        require (msg.sender != marketingFund && msg.sender != devFund);
        makeDeposit();
    }


    //make a contribution to the system
    function makeDeposit() nonReentrant private {
        if (usersCashback[msg.sender] > 0) collectCashback();
        if (msg.value > 0) {

            if (!alreadyDeposited[msg.sender]) {
                countOfInvestors += 1;
                address referrer = bytesToAddress(msg.data);
                if (referrer != msg.sender) userReferral[msg.sender] = referrer;
                alreadyDeposited[msg.sender] = true;
            }

            if (userReferral[msg.sender] != address(0)) {
                uint refAmount = msg.value.mul(refPercent).div(100);
                userReferral[msg.sender].transfer(refAmount);
                refferalCollected[userReferral[msg.sender]] = refferalCollected[userReferral[msg.sender]].add(refAmount);
            }

            if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
                collectPercent();
            }

            userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
            userTime[msg.sender] = now;
            chargeCashBack();

            //sending money for marketing
            marketingFund.transfer(msg.value.mul(marketingPercent).div(100));
            //sending money to dev team
            uint devMoney = msg.value.mul(devPercent).div(100);
            countOfDev = countOfDev.add(devMoney);
            devFund.transfer(devMoney);

        } else {
            collectPercent();
        }
    }

    function collectCashback() private {
        uint val = usersCashback[msg.sender];
        usersCashback[msg.sender] = 0;
        msg.sender.transfer(val);
    }

    // check cashback action and cashback accrual
    function chargeCashBack() private {
        uint cashbackValue = 0;
        // action 1
        if ( (now >= beginCashBackTime1) && (now<=endCashBackTime1) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent1level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent1level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent1level3).div(1000);
        }
        // action 2
        if ( (now >= beginCashBackTime2) && (now<=endCashBackTime2) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent2level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent2level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent2level3).div(1000);
        }
        // action 3
        if ( (now >= beginCashBackTime3) && (now<=endCashBackTime3) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent3level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent3level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent3level3).div(1000);
        }
        // action 4
        if ( (now >= beginCashBackTime4) && (now<=endCashBackTime4) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent4level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent4level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent4level3).div(1000);
        }
        // action 5
        if ( (now >= beginCashBackTime5) && (now<=endCashBackTime5) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent5level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent5level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent5level3).div(1000);
        }
        // action 6
        if ( (now >= beginCashBackTime6) && (now<=endCashBackTime6) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent6level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent6level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent6level3).div(1000);
        }
        // action 7
        if ( (now >= beginCashBackTime7) && (now<=endCashBackTime7) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent7level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent7level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent7level3).div(1000);
        }
        // action 8
        if ( (now >= beginCashBackTime8) && (now<=endCashBackTime8) ){
            if ( (msg.value >= minDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel1) ) cashbackValue = msg.value.mul(cashbackPercent8level1).div(1000);
            if ( (msg.value > maxDepCashBackLevel1) && (msg.value <= maxDepCashBackLevel2) ) cashbackValue = msg.value.mul(cashbackPercent8level2).div(1000);
            if ( (msg.value > maxDepCashBackLevel2) && (msg.value <= maxDepCashBackLevel3) ) cashbackValue = msg.value.mul(cashbackPercent8level3).div(1000);
        }

        usersCashback[msg.sender] = usersCashback[msg.sender].add(cashbackValue);
    }
    
    //return of interest on the deposit
    function collectPercent() isIssetUser timePayment internal {
        //if the user received 150% or more of his contribution, delete the user
        if ((userDeposit[msg.sender].mul(15).div(10)) <= persentWithdraw[msg.sender]) {
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


    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    //refund of the amount available for withdrawal on deposit
    function payoutAmount() public view returns(uint) {
        uint rate = userDeposit[msg.sender].mul(persent).div(100000);
        uint interestRate = now.sub(userTime[msg.sender]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate).add(usersCashback[msg.sender]);
        return (withdrawalAmount);
    }

    function userPayoutAmount(address _user) public view returns(uint) {
        uint rate = userDeposit[_user].mul(persent).div(100000);
        uint interestRate = now.sub(userTime[_user]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate).add(usersCashback[_user]);
        return (withdrawalAmount);
    }

    function getInvestedAmount(address investor) public view returns(uint) {
        return userDeposit[investor];
    }
    
    function getLastDepositeTime(address investor) public view returns(uint) {
        return userTime[investor];
    }
    
    function getPercentWitdraw(address investor) public view returns(uint) {
        return persentWithdraw[investor];
    }
    
    function getRefferalsCollected(address refferal) public view returns(uint) {
        return refferalCollected[refferal];
    }
    
}