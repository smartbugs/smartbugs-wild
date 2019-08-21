pragma solidity ^0.4.6;

contract token {
	function transferFrom(address sender, address receiver, uint amount) returns(bool success){}
	function burn() {}
}

contract SafeMath {
  

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}


contract Crowdsale is SafeMath {
    /* tokens will be transfered from this address (92M) */
	address public beneficiary = 0xbB93222C54f72ae99b2539a44093f2ED62533EBE;
	/* if the funding goal is not reached, investors may withdraw their funds,this is the minimum target */
	uint public fundingGoal = 1200000;
	/*  maximum amount of tokens to be sold */
	uint public maxGoal = 92000000;
	/* how much has been raised by crowdale ( ETH) */
	uint public amountRaised;
	/* the start date of the crowdsale */
	uint public start = 1493727424;
	/* the number of tokens already sold */
	uint public tokensSold;
	/* there are different prices in different time intervals */
	uint[2] public deadlines = [1494086400,1496757600];
	uint[2] public prices = [5000000000000000 ,6250000000000000 ];
	/* the address of the token contract */
	token public tokenReward;
	/* the balances (in ETH) of all investors */
	mapping(address => uint256) public balanceOf;
	/* indicated if the funding goal has been reached. */
	bool fundingGoalReached = false;
	/* indicates if the crowdsale has been closed already */
	bool crowdsaleClosed = false;
	/* the multisignature wallet on which the funds will be stored */
	address msWallet = 0x82612343BD6856E2A90378fAdeB5FFd950C348C9;
	/* notifying transfers and the success of the crowdsale*/
	event GoalReached(address beneficiary, uint amountRaised);
	event FundTransfer(address backer, uint amount, bool isContribution, uint amountRaised);



    /*  initialization, set the voise token address */
    function Crowdsale( ) {
        tokenReward = token(0x82665764ea0b58157E1e5E9bab32F68c76Ec0CdF);
    }

    /* invest by sending ether to the contract. */
    function () payable{
		if(msg.sender != msWallet) //do not trigger investment if the multisig wallet is returning the funds
        	invest(msg.sender);
    }

    /* function to invest in the crowdsale
    *  only callable if the crowdsale started and hasn't been closed already and the maxGoal wasn't reached yet.
    *  the current token price is looked up and the corresponding number of tokens is transfered to the receiver.
    *  the sent value is directly forwarded to a safe multisig wallet.
    *  this method allows to purchase tokens in behalf of another address.*/
    function invest(address receiver) payable{
    	uint amount = msg.value;
    	uint price = getPrice();
    	if(price > amount) throw;
		uint numTokens = amount / price;
		if (crowdsaleClosed||now<start||safeAdd(tokensSold,numTokens)>maxGoal) throw;
		if(!msWallet.send(amount)) throw;
		balanceOf[receiver] = safeAdd(balanceOf[receiver],amount);
		amountRaised = safeAdd(amountRaised, amount);
		tokensSold+=numTokens;
		if(!tokenReward.transferFrom(beneficiary, receiver, numTokens)) throw;
        FundTransfer(receiver, amount, true, amountRaised);
    }

    /* looks up the current token price */
    function getPrice() constant returns (uint256 price){
        for(var i = 0; i < deadlines.length; i++)
            if(now<deadlines[i])
                return prices[i];
        return prices[prices.length-1];//should never be returned, but to be sure to not divide by 0
    }

    modifier afterDeadline() { if (now >= deadlines[deadlines.length-1]) _; }

    /* checks if the goal or time limit has been reached and ends the campaign */
    function checkGoalReached() afterDeadline {
        if (tokensSold >= fundingGoal){
            fundingGoalReached = true;
            tokenReward.burn(); //burn remaining tokens 
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    /* allows the funders to withdraw their funds if the goal has not been reached.
	*  only works after funds have been returned from the multisig wallet. */
	function safeWithdrawal() afterDeadline {
		uint amount = balanceOf[msg.sender];
		if(address(this).balance >= amount){
			balanceOf[msg.sender] = 0;
			if (amount > 0) {
				if (msg.sender.send(amount)) {
					FundTransfer(msg.sender, amount, false, amountRaised);
				} else {
					balanceOf[msg.sender] = amount;
				}
			}
		}
    }

}