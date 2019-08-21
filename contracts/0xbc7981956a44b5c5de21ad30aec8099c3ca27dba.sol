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
*
*	RECOMMENDED GAS LIMIT: 150000
*	RECOMMENDED GAS PRICE: https://ethgasstation.info/
*	
*	THE PROJECT HAS HIGH RISKS! 
*	PROJECT MAKE PAYMENTS IF BALANCE HAS ETHER! 
*/

contract HodlETH {
    // records amounts invested
    mapping (address => uint) public userInvested;
    // records blocks at which investments were made
    mapping (address => uint) public entryTime;
    // records how much you withdraw
    mapping (address => uint) public withdrawnAmount;
    //records you use the referral program or not
    mapping (address => uint) public referrerOn;
    // marketing fund 6%
    address public advertisingFund = 0x01429d58058B3e84F6f264D91254EA3a96E1d2B7; 
    uint public advertisingPercent = 6;
	// tech support fund 2 %
	address techSupportFund = 0x0D5dB78b35ecbdD22ffeA91B46a6EC77dC09EA4a;		
	uint public techSupportPercent = 2;
	// "hodl" mode
    uint public startPercent = 25;			// 2.5%
	uint public fiveDayHodlPercent = 30;	// 3%
    uint public tenDayHodlPercent = 35;		// 3.5%
	uint public twentyDayHodlPercent = 45;	// 4.5%
	// bonus percent of balance
	uint public lowBalance = 500 ether;
	uint public middleBalance = 2000 ether;
	uint public highBalance = 3500 ether;
    uint public soLowBalanceBonus = 5;		// 0.5%
	uint public lowBalanceBonus = 10;		// 1%
	uint public middleBalanceBonus = 15;	// 1.5%
	uint public highBalanceBonus = 20;		// 2%
	
	
    
    // get bonus percent
    function bonusPercent() public view returns(uint){
        
        uint balance = address(this).balance;
        
        if (balance < lowBalance){
            return (soLowBalanceBonus);		// if balance < 500 ether return 0.5%
        } 
        if (balance > lowBalance && balance < middleBalance){
            return (lowBalanceBonus); 		// if balance > 500 ether and balance < 2000 ether return 1%
        } 
        if (balance > middleBalance && balance < highBalance){
            return (middleBalanceBonus); 	// if balance > 2000 ether and balance < 3500 ether return 1.5%
        }
        if (balance > highBalance){
            return (highBalanceBonus);		// if balance > 3500 ether return 2%
        }
        
    }
    // get personal percent
    function personalPercent() public view returns(uint){
        
        uint hodl = block.number - entryTime[msg.sender]; 
		// how many blocks you hold, 1 day = 6100 blocks
         if (hodl < 30500){
            return (startPercent);			// if hodl < 5 day, return 2.5%
        }
		if (hodl > 30500 && hodl < 61000){
            return (fiveDayHodlPercent);	// if hodl > 5 day and hodl < 10 day, return 3%
        }
        if (hodl > 61000 && hodl < 122000){
            return (tenDayHodlPercent);		// if hodl > 10 day and hodl < 20 day, return 3.5%
        }
		if (hodl > 122000){
            return (twentyDayHodlPercent);	// if hodl > 20 day, return 3.5%
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
    
   // return of deposit(userInvested - withdrawnAmount - (userInvested / 10(fund fee)) , after delete user record
    function returnInvestment() timeWithdrawn private{
        if(userInvested[msg.sender] > 0){
            uint refundAmount = userInvested[msg.sender] - withdrawnAmount[msg.sender] - (userInvested[msg.sender] / 10);
            require(userInvested[msg.sender] > refundAmount, 'You have already returned the investment');
			userInvested[msg.sender] = 0;
            entryTime[msg.sender] = 0;
            withdrawnAmount[msg.sender] = 0;
            msg.sender.transfer(refundAmount);
        }
    }
    // make a contribution
    function invest() timeWithdrawn maxInvested  private {
        if (msg.value > 0 ){
			// call terminal    
			terminal();
			// record invested amount (msg.value) of this transaction
			userInvested[msg.sender] += msg.value;
			// sending fee for advertising and tech support
			advertisingFund.transfer(msg.value * advertisingPercent / 100);
			techSupportFund.transfer(msg.value * techSupportPercent / 100);
        
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
        // if the user received 150% or more of his contribution, delete the user
        if (userInvested[msg.sender] * 15 / 10 < withdrawnAmount[msg.sender]){
            userInvested[msg.sender] = 0;
            entryTime[msg.sender] = 0;
            withdrawnAmount[msg.sender] = 0;
            referrerOn[msg.sender] = 0; 
        } else {
            // you percent = bonusPercent + personalPercent, min 3% and max 6.5%
            uint percent = bonusPercent() + personalPercent();
            // calculate profit amount as such:
            // amount = (amount invested) * you percent * (blocks since last transaction) / 6100
            // 6100 is an average block count per day produced by Ethereum blockchain
            uint amount = userInvested[msg.sender] * percent / 1000 * ((block.number - entryTime[msg.sender]) / 6100);
            // record block number
            entryTime[msg.sender] = block.number;
            // record withdraw amount
            withdrawnAmount[msg.sender] += amount;
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
        referrerOn[msg.sender] = 1;
        uint refBonus = msg.value * 20 / 1000;
        referrer.transfer(refBonus);    
        }
    }
    
    modifier timeWithdrawn(){
        require(entryTime[msg.sender] + 3050 < block.number, 'Withdraw and deposit no more 1 time per 12 hour');
        _;
    }
    
    
    modifier maxInvested(){
        require(msg.value <= 25 ether, 'Max invested 25 ETH per 12 hours');
        _;
    }

}