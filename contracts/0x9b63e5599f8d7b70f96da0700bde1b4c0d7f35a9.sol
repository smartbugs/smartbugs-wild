pragma solidity 0.4.25;

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
        uint256 c = a / b;
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

contract DoubleUp {
    //using the library of safe mathematical operations    
    using SafeMath
    for uint;
    //array of last users withdrawal
    mapping(address => uint) public usersTime;
    //array of users investment ammount
    mapping(address => uint) public usersInvestment;
    //array of dividends user have withdrawn
    mapping(address => uint) public dividends;
    //wallet for a project foundation
    address public projectFund = 0xe8eb761B83e035b0804C60D2025Ec00f347EC793;
    //fund to project
    uint public projectPercent = 9;
    //percent of refferer
    uint public referrerPercent = 2;
    //percent of refferal
    uint public referralPercent = 1;
    //the ammount of returned from the begin of this day (GMT)
    uint public ruturnedOfThisDay = 0;
    //the day of last return
    uint public dayOfLastReturn = 0;
    //max ammount of return per day
    uint public maxReturn = 500 ether;
    //percents:
    uint public startPercent = 200;     //2% per day
    uint public lowPercent = 300;       //3% per day
    uint public middlePercent = 400;    //4% per day
    uint public highPercent = 500;      //5% per day
    //interest rate
    uint public stepLow = 1000 ether;
    uint public stepMiddle = 2500 ether;
    uint public stepHigh = 5000 ether;
    uint public countOfInvestors = 0;

    modifier isIssetUser() {
        require(usersInvestment[msg.sender] > 0, "Deposit not found");
        _;
    }

    //pay dividends on the deposit
    function collectPercent() isIssetUser internal {
        //if the user received 200% or more of his contribution, delete the user
        if ((usersInvestment[msg.sender].mul(2)) <= dividends[msg.sender]) {
            //this should never execute, but lets stay it here
            usersInvestment[msg.sender] = 0;
            usersTime[msg.sender] = 0;
            dividends[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            usersTime[msg.sender] = now;
            dividends[msg.sender] += payout;
            msg.sender.transfer(payout);
            //check again for 200%
            if ((usersInvestment[msg.sender].mul(2)) <= dividends[msg.sender]) {
                usersInvestment[msg.sender] = 0;
                usersTime[msg.sender] = 0;
                dividends[msg.sender] = 0;
            }    
        }
    }

    //calculation of the current percent rate
    function percentRate() public view returns(uint) {
        //get contract balance
        uint balance = address(this).balance;
        //calculate percent rate
        if (balance < stepLow) {
            return (startPercent);
        }
        if (balance >= stepLow && balance < stepMiddle) {
            return (lowPercent);
        }
        if (balance >= stepMiddle && balance < stepHigh) {
            return (middlePercent);
        }
        if (balance >= stepHigh) {
            return (highPercent);
        }
    }

    //refund of the amount available for withdrawal on deposit
    function payoutAmount() public view returns(uint) {
        uint percent = percentRate();
        uint rate = usersInvestment[msg.sender].mul(percent).div(10000);//per day
        uint interestRate = now.sub(usersTime[msg.sender]);
        uint withdrawalAmount = rate.mul(interestRate).div(60*60*24);
        uint rest = (usersInvestment[msg.sender].mul(2)).sub(dividends[msg.sender]);
        if(withdrawalAmount>rest) withdrawalAmount = rest;
        return (withdrawalAmount);
    }

    //make a contribution to the fund
    function makeDeposit() private {
        if (msg.value > 0) {
            //check for referral
            uint projectTransferPercent = projectPercent;
            if(msg.data.length == 20 && msg.value >= 5 ether){
                address referrer = _bytesToAddress(msg.data);
                if(usersInvestment[referrer] >= 1 ether){
                    referrer.transfer(msg.value.mul(referrerPercent).div(100));
                    msg.sender.transfer(msg.value.mul(referralPercent).div(100));
                    projectTransferPercent = projectTransferPercent.sub(referrerPercent.add(referralPercent));
                }
            }
            if (usersInvestment[msg.sender] > 0) {
                collectPercent();
            }
            else {
                countOfInvestors += 1;
            }
            usersInvestment[msg.sender] = usersInvestment[msg.sender].add(msg.value);
            usersTime[msg.sender] = now;
            //sending money for advertising
            projectFund.transfer(msg.value.mul(projectTransferPercent).div(100));
        } else {
            collectPercent();
        }
    }

    //return of deposit balance
    function returnDeposit() isIssetUser private {
        
        //check for day limit
        require(((maxReturn.sub(ruturnedOfThisDay) > 0) || (dayOfLastReturn != now.div(1 days))), 'Day limit of return is ended');
        //check that user didnt get more than 91% of his deposit 
        require(usersInvestment[msg.sender].sub(usersInvestment[msg.sender].mul(projectPercent).div(100)) > dividends[msg.sender].add(payoutAmount()), 'You have already repaid your 91% of deposit. Use 0!');
        
        //pay dividents
        collectPercent();
        //userDeposit-percentWithdraw-(userDeposit*projectPercent/100)
        uint withdrawalAmount = usersInvestment[msg.sender].sub(dividends[msg.sender]).sub(usersInvestment[msg.sender].mul(projectPercent).div(100));
        //if this day is different from the day of last return then recharge max reurn 
        if(dayOfLastReturn!=now.div(1 days)) { ruturnedOfThisDay = 0; dayOfLastReturn = now.div(1 days); }
        
        if(withdrawalAmount > maxReturn.sub(ruturnedOfThisDay)){
            withdrawalAmount = maxReturn.sub(ruturnedOfThisDay);
            //recalculate the rest of users investment (like he make it right now)
            usersInvestment[msg.sender] = usersInvestment[msg.sender].sub(withdrawalAmount.add(dividends[msg.sender]).mul(100).div(100-projectPercent));
            usersTime[msg.sender] = now;
            dividends[msg.sender] = 0;
        }
        else
        {
             //delete user record
            usersInvestment[msg.sender] = 0;
            usersTime[msg.sender] = 0;
            dividends[msg.sender] = 0;
        }
        ruturnedOfThisDay += withdrawalAmount;
        msg.sender.transfer(withdrawalAmount);
    }

    function() external payable {
        //refund of remaining funds when transferring to a contract 0.00000112 ether
        if (msg.value == 0.00000112 ether) {
            returnDeposit();
        } else {
            makeDeposit();
        }
    }
    
    function _bytesToAddress(bytes data) private pure returns(address addr) {
        assembly {
            addr := mload(add(data, 20)) 
        }
    }
}