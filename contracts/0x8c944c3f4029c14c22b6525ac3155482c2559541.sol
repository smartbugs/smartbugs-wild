pragma solidity ^0.4.13;

contract token {
    function transfer(address _to, uint256 _value);
    function balanceOf(address _owner) constant returns (uint256 balance);	
}

contract BDSM_Presale {
    
    token public sharesTokenAddress; // token address
    address public owner;
    address public safeContract;

	uint public presaleStart_6_December = 1512518460; // start Presale - 6 December 2017
	uint public presaleStop_13_December = 1513123260; // end Presale - 13 December 2017
	string public price = "0.0035 Ether for 2 microBDSM";
	uint realPrice = 0.0035 * 1 ether; // ETH for 1 package of tokens
	uint coeff = 200000; // capacity of 1 package
	
	uint256 public tokenSold = 0; // tokens sold
	uint256 public tokenFree = 0; // tokens free
	bool public presaleClosed = false;
    bool public tokensWithdrawn = false;
	
	event TokenFree(uint256 value);
	event PresaleClosed(bool value);
    
	function BDSM_Presale(address _tokenAddress, address _owner, address _stopScamHolder) {
		owner = _owner;
		sharesTokenAddress = token(_tokenAddress);
		safeContract = _stopScamHolder;
	}

	function() payable {
	    
		tokenFree = sharesTokenAddress.balanceOf(this); // free tokens count
		
		if (now < presaleStart_6_December) {
		    msg.sender.transfer(msg.value);
		}
		else if (now > presaleStop_13_December) {
			msg.sender.transfer(msg.value); // if presale closed - cash back
			if(!tokensWithdrawn){ // when presale closed - unsold tokens transfer to stopScamHolder
			    sharesTokenAddress.transfer(safeContract, sharesTokenAddress.balanceOf(this));
			    tokenFree = sharesTokenAddress.balanceOf(this);
			    tokensWithdrawn = true;
			    presaleClosed = true;
			}
		} 
		else if (presaleClosed) {
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
				if(tokenFree==0) presaleClosed = true;
			} else { // free tokens < tokens to buy 
				uint256 sendETH = tokenFree * realPrice / coeff; // price for all free tokens
				owner.transfer(sendETH); 
				sharesTokenAddress.transfer(msg.sender, tokenFree); 
				msg.sender.transfer(msg.value - sendETH); // more than need - cash back
				tokenSold += tokenFree;
				tokenFree = sharesTokenAddress.balanceOf(this);
				presaleClosed = true;
			}
		}
		TokenFree(tokenFree);
		PresaleClosed(presaleClosed);
	}
}