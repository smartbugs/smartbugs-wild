pragma solidity ^0.4.13;

contract token {
    function transfer(address _to, uint256 _value);
    function balanceOf(address _owner) constant returns (uint256 balance);	
}

contract BDSM_Crowdsale {
    
    token public sharesTokenAddress; // token address
    address public owner;
    address public safeContract;

	uint public startICO_20_December = 1513728060; // start ICO - 20 December 2017
	uint public stopICO_20_March = 1521504060; // end ICO - 20 March 2018
	uint public priceIncrease_20_January = 1516406460; // if time later than - 20 January 2018 - price +50%
	uint public priceIncrease_20_February = 1519084860; // if time later than - 20 February 2018 - price +100%
	string public price = "0.0035 Ether for 1 microBDSM";
	uint realPrice = 0.0035 * 1 ether; // ETH for 1 package of tokens
	uint coeff = 100000; // capacity of 1 package
	
	uint256 public tokenSold = 0; // tokens sold
	uint256 public tokenFree = 0; // tokens free
	bool public crowdsaleClosed = false;
    bool public tokensWithdrawn = false;
	
	event TokenFree(uint256 value);
	event CrowdsaleClosed(bool value);
    
	function BDSM_Crowdsale(address _tokenAddress, address _owner, address _stopScamHolder) {
		owner = _owner;
		sharesTokenAddress = token(_tokenAddress);
		safeContract = _stopScamHolder;
	}

	function() payable {
	    
	    if(now > priceIncrease_20_February){
	        price = "0.007 Ether for 1 microBDSM";
	        realPrice = 0.007 * 1 ether; 
	    } 
	    else if(now > priceIncrease_20_January){
	        price = "0.00525 Ether for 1 microBDSM";
	        realPrice = 0.00525 * 1 ether;
	    } 
	    
		tokenFree = sharesTokenAddress.balanceOf(this); // free tokens count
		
		if (now < startICO_20_December) {
		    msg.sender.transfer(msg.value);
		}
		else if (now > stopICO_20_March) {
			msg.sender.transfer(msg.value); // if crowdsale closed - cash back
			if(!tokensWithdrawn){ // when crowdsale closed - unsold tokens transfer to stopScamHolder
			    sharesTokenAddress.transfer(safeContract, sharesTokenAddress.balanceOf(this));
			    tokenFree = sharesTokenAddress.balanceOf(this);
			    tokensWithdrawn = true;
			    crowdsaleClosed = true;
			}
		} 
		else if (crowdsaleClosed) {
			msg.sender.transfer(msg.value); // if no more tokens - cash back
		} 
		else {
			uint256 tokenToBuy = msg.value / realPrice * coeff; // tokens to buy
			if(tokenToBuy <= 0) msg.sender.transfer(msg.value); // mistake protector
			require(tokenToBuy > 0);
			uint256 actualETHTransfer = tokenToBuy * realPrice / coeff;
			if (tokenFree >= tokenToBuy) { // free tokens >= tokens to buy, sell tokens
				owner.transfer(actualETHTransfer);
				if (msg.value > actualETHTransfer){ // if more than need - cash back
					msg.sender.transfer(msg.value - actualETHTransfer);
				}
				sharesTokenAddress.transfer(msg.sender, tokenToBuy);
				tokenSold += tokenToBuy;
				tokenFree -= tokenToBuy;
				if(tokenFree==0) crowdsaleClosed = true;
			} else { // free tokens < tokens to buy 
				uint256 sendETH = tokenFree * realPrice / coeff; // price for all free tokens
				owner.transfer(sendETH); 
				sharesTokenAddress.transfer(msg.sender, tokenFree); 
				msg.sender.transfer(msg.value - sendETH); // more than need - cash back
				tokenSold += tokenFree;
				tokenFree = sharesTokenAddress.balanceOf(this);
				crowdsaleClosed = true;
			}
		}
		TokenFree(tokenFree);
		CrowdsaleClosed(crowdsaleClosed);
	}
}