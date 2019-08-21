/*******************************/
/* Solidity Contract By Younes */
/**** L.younes@1fancy.com ******/
/****** www.1fancy.com *********/
/*******************************/

pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount);
}

contract MiCarsICO {
	// Beneficiary Address
	uint128 private decimals = 1000000000000000000;
    address public beneficiary = 0x8f42914C201AcDd8a2769211C862222Ec56eea40;
    address public owner = beneficiary;
	
	// Start date vendredi 29 décembre 2017 00:00:00
	uint public startdate = now;
	// Pré ico round 1 fin: vendredi 5 janvier 2018 23:59:3
	uint public deadlinePreIcoOne = 1515196740;
	
	// Pré ico round 2 fin: vendredi 12 janvier 2018 23:59:3
    uint public deadlinePreIcoTwo = 1515801540;	
	
	// Fianl Tuesday fin: mardi 13 février 2018 23:59:3
    uint public deadline = 1518566340;

	
	// Min token per transaction
    uint public vminEtherPerPurchase = 0.0011 * 1 ether;
	
	// Max Token per transaction
    uint public vmaxEtherPerPurchase = 225 * 1 ether;
	
	// Initial Starting price per token
    uint public price = 0.000385901 * 1 ether;
    uint public updatedPrice  = 0.000515185 * 1 ether;
	
	// Amount raised and deadlines in seconds
    uint public amountRaised;
    uint public sentToken;
    

	

	
	// Token Address
    token public tokenReward = token(0xdd5a3aeef473401c23f24c4c6b9cd1b0808fbb36);
    mapping(address => uint256) public balanceOf;
	
    bool crowdsaleClosed = false;
    bool price_rate_changed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function MiCarsICO() {}

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	  }
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		if (a == 0) {
		  return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}
  
	modifier isOwner {
	  require(msg.sender == owner);
	  _;
	 }
	

	function kill() isOwner public {
        selfdestruct(beneficiary);
    }

    function EmergencyPause() isOwner public {
        crowdsaleClosed = true;
    }
    function EmergencyUnPause() isOwner public {
        crowdsaleClosed = false;
    }
	
	 /**
     * Withdraw the funds
     *
     */
    function safeWithdrawal(uint _amounty) isOwner public {
			uint amounted = _amounty;
            
            if (beneficiary.send(amounted)) {
                FundTransfer(beneficiary, amounted, false);
            }
    }
	
    function UpdatePrice(uint _new_price) isOwner public {
          updatedPrice = _new_price;
		  price_rate_changed = true;
    }

    function () payable   {
        require(crowdsaleClosed == false);

		if (price_rate_changed == false) {
					
			// Token price in 1st week Pre Ico
			if (now <= deadlinePreIcoOne) {
				price = 0.000385901 * 1 ether;
			}
			
			// Token price in 2nd week Pre Ico
			else if (now > deadlinePreIcoOne && now <= deadlinePreIcoTwo) {
				price = 0.000411628 * 1 ether;
			}
			
			// Token price in 3th week Pre Ico
			else if (now > deadlinePreIcoTwo && now <= deadline) {
				price = 0.000515185 * 1 ether;
			}
			// Token fixed price in any issue happend
			else {
				price = 0.000515185 * 1 ether;
			}
		// Regular token price
		} else if (price_rate_changed == true) {
			price = updatedPrice * 1 ether;
		} else {
			price = 0.000515185 * 1 ether;
		}
		
		uint amount = msg.value;

		uint calculedamount = mul(amount, decimals);
		uint tokentosend = div(calculedamount, price);


        if (msg.value >= vminEtherPerPurchase && msg.value <= vmaxEtherPerPurchase) {
				
				balanceOf[msg.sender] += amount;
				FundTransfer(msg.sender, amount, true);
				tokenReward.transfer(msg.sender, tokentosend);

				amountRaised += amount;
				sentToken += tokentosend;
						
							
		} else {
			revert();
		}
        
    }

}