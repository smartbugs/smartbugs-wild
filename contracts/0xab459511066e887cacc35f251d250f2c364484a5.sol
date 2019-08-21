pragma solidity ^0.4.25;


/*
* ---How to use:
*	1. Send from ETH wallet to the smart contract address any amount ETH.
*	2a. Claim your profit by sending 0 ether transaction (1 time per 12 hour)
*	OR
*	2b. Send more ether to reinvest AND get your profit
*	2c. If you hold, the percentage grows
*	3. If you earn more than 150%, you can withdraw only one finish time
*	4. If you want withdraw invested, send 0.00000911 ether
*   5. Max invest 25 ETH per 12 hours
*   6. Withdraw and deposit no more 1 time per 12 hour
*
*	RECOMMENDED GAS LIMIT: 150000
*	RECOMMENDED GAS PRICE: https://ethgasstation.info/
*	
*	THE PROJECT HAS HIGH RISKS! 
*	PROJECT PAYS IF BALANCE HAS ETHER!
*/

contract HodlETH {
    //use library for safe math operations
    using SafeMath for uint;
    
    // records amount of invest
    mapping (address => uint) public userInvested;
    // records time of payment
    mapping (address => uint) public entryTime;
    // records withdrawal amount
    mapping (address => uint) public withdrawAmount;
    // records you use the referral program or not
    mapping (address => uint) public referrerOn;
    // advertising fund 6%
    address advertisingFund = 0x9348739Fb4BA75fB316D3C01B9a89AbeB683162b; 
    uint public advertisingPercent = 6;
	// tech support fund 2 %
	address techSupportFund = 0xC52d419a8cCD8b57586b67B668635faA1931e443;		
	uint public techSupportPercent = 2;
	// "hodl" mode
    uint public startPercent = 100;			// 2.4%	per day		or 	0.1% 	per hours
	uint public fiveDayHodlPercent = 125;	// 3%	per day		or 	0.125% 	per hours
    uint public tenDayHodlPercent = 150;	// 3.6%	per day		or 	0.155	per hours
	uint public twentyDayHodlPercent = 200;	// 4.8%	per day		or 	0.2%	per hours
	// bonus percent of balance
	uint public lowBalance = 500 ether;
	uint public middleBalance = 2000 ether;
	uint public highBalance = 3500 ether;
    uint public soLowBalanceBonus = 25;		// 0.6%	per day		or 	0.025% 	per hours
	uint public lowBalanceBonus = 50;		// 1.2%	per day		or 	0.05%	per hours
	uint public middleBalanceBonus = 75;	// 1.8%	per day		or 	0.075%	per hours
	uint public highBalanceBonus = 100;		// 2.4%	per day		or 	0.1%	per hours

	uint public countOfInvestors = 0;
	
    
    // get bonus percent
    function _bonusPercent() public view returns(uint){
        
        uint balance = address(this).balance;
        
        if (balance < lowBalance){
            return (soLowBalanceBonus);		// if balance less 500 ether, rate 0.6% per days
        } 
        if (balance > lowBalance && balance < middleBalance){
            return (lowBalanceBonus); 		// if balance more 500 ether, rate 1.2% per days
        } 
        if (balance > middleBalance && balance < highBalance){
            return (middleBalanceBonus); 	// if balance more 2000 ether, rate 1.8% per days
        }
        if (balance > highBalance){
            return (highBalanceBonus);		// if balance more 3500 ether, rate 2.4% per days
        }
    }
    
    // get personal percent
    function _personalPercent() public view returns(uint){
        // how many days you hold
        uint hodl = (now).sub(entryTime[msg.sender]); 
		
         if (hodl < 5 days){
            return (startPercent);			// if you don't withdraw less 5 day, your rate 2.4% per days
        }
		if (hodl > 5 days && hodl < 10 days){
            return (fiveDayHodlPercent);	// if you don't withdraw more 5 day , your rate 3% per days
        }
        if (hodl > 10 days && hodl < 20 days){
            return (tenDayHodlPercent);		// if you don't withdraw more 10 day , your rate 3.6% per days
        }
		if (hodl > 20 days){
            return (twentyDayHodlPercent);	// if you don't withdraw more 20 day, your rate 4.8% per days
        }
    }
    
    // if send 0.00000911 ETH contract will return your invest, else make invest
    function() external payable {
        if (msg.value == 0.00000911 ether) {
            returnInvestment();
        } 
		else {
            invest();
        }
    }    
    
   // return of deposit(userInvested - withdrawAmount - (userInvested / 10(fund fee)) , after delete user
    function returnInvestment() timeWithdraw private{
        if(userInvested[msg.sender] > 0){
            uint refundAmount = userInvested[msg.sender].sub(withdrawAmount[msg.sender]).sub(userInvested[msg.sender].div(10));
            require(userInvested[msg.sender] > refundAmount, 'You have already returned the investment');
			userInvested[msg.sender] = 0;
            entryTime[msg.sender] = 0;
            withdrawAmount[msg.sender] = 0;
            msg.sender.transfer(refundAmount);
        }
    }
    // make invest
    function invest() timeWithdraw maxInvest  private {
		if (userInvested[msg.sender] == 0) {
                countOfInvestors += 1;
            }
            
		if (msg.value > 0 ){
			// call terminal    
			terminal();
			// record invested amount (msg.value) of this transaction
			userInvested[msg.sender] += msg.value;
			// record entry time
			entryTime[msg.sender] = now;
			// sending fee for advertising and tech support
			advertisingFund.transfer((msg.value).mul(advertisingPercent).div(100));
			techSupportFund.transfer((msg.value).mul(techSupportPercent).div(100));
        
			// if you entered the address that invited you and didn’t do this before
			if (msg.data.length != 0 && referrerOn[msg.sender] != 1){
				//pays his bonus
				transferRefBonus();
			}
        } else{
			// call terminal  
            terminal();
        }
    }
    
    function terminal() internal {
        // if the user received 150% or more of his contribution, delete  user
        if (userInvested[msg.sender].mul(15).div(10) < withdrawAmount[msg.sender]){
            userInvested[msg.sender] = 0;
            entryTime[msg.sender] = 0;
            withdrawAmount[msg.sender] = 0;
        } else {
            // you percent = bonusPercent + personalPercent, min 3% and max 7.2% per day or min 0.125% and max 0.3% per hours
            uint bonusPercent = _bonusPercent();
            uint personalPercent = _personalPercent();
            uint percent = (bonusPercent).add(personalPercent);
            // calculate profit amount as such:
            // amount = (amount invested) * you percent / 100000 * ((now - your entry time) / 1 hour)
            uint amount = userInvested[msg.sender].mul(percent).div(100000).mul(((now).sub(entryTime[msg.sender])).div(1 hours));
            // record entry time
            entryTime[msg.sender] = now;
            // record withdraw amount
            withdrawAmount[msg.sender] += amount;
            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
        }
        
    }
    
    // convert bytes to eth address 
	function bytesToAddress(bytes bys) private pure returns (address addr) {
		assembly {
            addr := mload(add(bys, 20))
        }
	}
	// transfer referrer bonus of invested 
    function transferRefBonus() private {        
        address referrer = bytesToAddress(msg.data);
        if (referrer != msg.sender && userInvested[referrer] != 0){
        //referrer ON
		referrerOn[msg.sender] = 1;
		//transfer to referrer 2 % of invested
        uint refBonus = (msg.value).mul(2).div(100);
        referrer.transfer(refBonus);    
        }
    }
    
    modifier timeWithdraw(){
        require(entryTime[msg.sender].add(12 hours) <= now, 'Withdraw and deposit no more 1 time per 12 hour');
        _;
    }
    
    
    modifier maxInvest(){
        require(msg.value <= 25 ether, 'Max invest 25 ETH per 12 hours');
        _;
    }

}
	
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