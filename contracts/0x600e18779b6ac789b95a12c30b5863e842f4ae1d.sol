pragma solidity ^0.4.8;

contract SmartRouletteToken 
{
   uint8 public decimals;
   function balanceOf( address who ) external constant returns (uint256);
   function gameListOf( address who ) external constant returns (bool);
   function getItemHolders(uint256 index) external constant returns(address);
   function getCountHolders() external constant returns (uint256);
   function getCountTempHolders() external constant returns(uint256);
   function getItemTempHolders(uint256 index) external constant returns(address);
   function tempTokensBalanceOf( address who ) external constant returns (uint256);
}

contract SmartRouletteDividend {

	address developer;
	address manager;

	SmartRouletteToken smartToken;
	uint256 decimal;

	struct DividendInfo
	{
	   uint256 amountDividend;
	   uint256 blockDividend;
	   bool AllPaymentsSent;
	}

	DividendInfo[] dividendHistory;

	address public gameAddress;

	uint256 public tokensNeededToGetPayment = 1000;


	function SmartRouletteDividend() {
		developer = msg.sender;
		manager = msg.sender;

		smartToken = SmartRouletteToken(0xcced5b8288086be8c38e23567e684c3740be4d48); //test 0xc46ed6ba652bd552671a46045b495748cd10fa04 main 0x2a650356bd894370cc1d6aba71b36c0ad6b3dc18
		decimal = 10**uint256(smartToken.decimals());		
	}
	

	modifier isDeveloper(){
		if (msg.sender!=developer) throw;
		_;
	}

	modifier isManager(){
		if (msg.sender!=manager && msg.sender!=developer) throw;
		_;
	}

	function changeTokensLimit(uint256 newTokensLimit) isDeveloper
	{
		tokensNeededToGetPayment = newTokensLimit;
	}
	function dividendCount() constant returns(uint256)
	{
		return dividendHistory.length;
	}

	function SetAllPaymentsSent(uint256 DividendNo) isManager
	{
		dividendHistory[DividendNo].AllPaymentsSent = true;
		// all fees (30000 gas * tx.gasprice for each transaction)
		if (manager.send(this.balance) == false) throw;
	}

	function changeDeveloper(address new_developer)
	isDeveloper
	{
		if(new_developer == address(0x0)) throw;
		developer = new_developer;
	}

	function changeManager(address new_manager)
	isDeveloper
	{
		if(new_manager == address(0x0)) throw;
		manager = new_manager;
	}

	function kill() isDeveloper {
		suicide(developer);
	}

	function getDividendInfo(uint256 index) constant returns(uint256 amountDividend, uint256 blockDividend, bool AllPaymentsSent)
	{
		amountDividend  = dividendHistory[index].amountDividend;
		blockDividend   = dividendHistory[index].blockDividend;
		AllPaymentsSent = dividendHistory[index].AllPaymentsSent;
	}


	//  get total count tokens (to calculate profit for one token)
	function get_CountProfitsToken() constant returns(uint256){
		uint256 countProfitsTokens = 0;

		mapping(address => bool) uniqueHolders;

		uint256 countHolders = smartToken.getCountHolders();
		for(uint256 i=0; i<countHolders; i++)
		{
			address holder = smartToken.getItemHolders(i);
			if(holder!=address(0x0) && !uniqueHolders[holder])
			{
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0)
				{
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[holder]=true;
						countProfitsTokens += (holdersTokens+tempTokens);
					}
				}
			}
		}

		uint256 countTempHolders = smartToken.getCountTempHolders();
		for(uint256 j=0; j<countTempHolders; j++)
		{
			address temp_holder = smartToken.getItemTempHolders(j);
			if(temp_holder!=address(0x0) && !uniqueHolders[temp_holder])
			{
				uint256 token_balance = smartToken.balanceOf(temp_holder);
				if(token_balance==0)
				{
					uint256 count_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
					if(count_tempTokens>0 && count_tempTokens/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[temp_holder]=true;
						countProfitsTokens += count_tempTokens;
					}
				}
			}
		}
		
		return countProfitsTokens;
	}

	function get_CountAllHolderForProfit() constant returns(uint256){
		uint256 countAllHolders = 0;

		mapping(address => bool) uniqueHolders;

		uint256 countHolders = smartToken.getCountHolders();
		for(uint256 i=0; i<countHolders; i++)
		{
			address holder = smartToken.getItemHolders(i);
			if(holder!=address(0x0) && !uniqueHolders[holder])
			{
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0)
				{
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[holder] = true;
						countAllHolders += 1;
					}
				}
			}
		}

		uint256 countTempHolders = smartToken.getCountTempHolders();
		for(uint256 j=0; j<countTempHolders; j++)
		{
			address temp_holder = smartToken.getItemTempHolders(j);
			if(temp_holder!=address(0x0) && !uniqueHolders[temp_holder])
			{
				uint256 token_balance = smartToken.balanceOf(temp_holder);
				if(token_balance==0)
				{
					uint256 coun_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
					if(coun_tempTokens>0 && coun_tempTokens/decimal >= tokensNeededToGetPayment)
					{
						uniqueHolders[temp_holder] = true;
						countAllHolders += 1;
					}
				}
			}
		}
		
		return countAllHolders;
	}

	// get holders addresses to make payment each of them
	function get_Holders(uint256 position) constant returns(address[64] listHolders, uint256 nextPosition) 
	{
		uint8 n = 0;		
		uint256 countHolders = smartToken.getCountHolders();
		for(; position < countHolders; position++){			
			address holder = smartToken.getItemHolders(position);
			if(holder!=address(0x0)){
				uint256 holdersTokens = smartToken.balanceOf(holder);
				if(holdersTokens>0){
					uint256 tempTokens = smartToken.tempTokensBalanceOf(holder);
					if((holdersTokens+tempTokens)/decimal >= tokensNeededToGetPayment){
						//
						listHolders[n++] = holder;
						if (n == 64) 
						{
							nextPosition = position + 1;
							return;
						}
					}
				}
			}
		}

		
		if (position >= countHolders)
		{			
			uint256 countTempHolders = smartToken.getCountTempHolders();			
			for(uint256 j=position-countHolders; j<countTempHolders; j++) 
			{							
				address temp_holder = smartToken.getItemTempHolders(j);
				if(temp_holder!=address(0x0)){
					uint256 token_balance = smartToken.balanceOf(temp_holder);
					if(token_balance==0){
						uint256 count_tempTokens = smartToken.tempTokensBalanceOf(temp_holder);
						if(count_tempTokens>0 && count_tempTokens/decimal >= tokensNeededToGetPayment){
							listHolders[n++] = temp_holder;
							if (n == 64) 
							{
								nextPosition = position + 1;
								return;
							}
						}
					}
				}

				position = position + 1;
			}
		}

		nextPosition = 0;
	}
	// Get profit for specified token holder
	// Function should be executed in blockDividend ! (see struct DividendInfo)
	// Don't call this function via etherescan.io
	// Example how to call via JavaScript and web3
	// var abiDividend = [...];
	// var holderAddress = "0xdd94ddf50485f41491c415e7133100e670cd4ef3";
	// var dividendIndex = 1;       // starts from zero
	// var blockDividend = 3527958; // see function getDividendInfo
	// web3.eth.contract(abiDividend).at("0x600e18779b6aC789b95a12C30b5863E842F4ae1d").get_HoldersProfit(dividendIndex, holderAddress, blockDividend, function(err, profit){
	//    alert("Your profit " + web3.fromWei(profit).toString(10) + "ETH");
	// });
	function get_HoldersProfit(uint256 dividendPaymentNum, address holder) constant returns(uint256){
		uint256 profit = 0;
		if(holder != address(0x0) && dividendHistory.length > 0 && dividendPaymentNum < dividendHistory.length){
			uint256 count_tokens = smartToken.balanceOf(holder) + smartToken.tempTokensBalanceOf(holder);
			if(count_tokens/decimal >= tokensNeededToGetPayment){
				profit = (count_tokens*dividendHistory[dividendPaymentNum].amountDividend)/get_CountProfitsToken();
			}
		}
		return profit;
	}

	// Since the full cycle of calculations in a smart contract costs a big amount of gas and the smart contract is not able to calculate the exact block
	// the major part of calculations is transferred to the server out of the smart contract (though using functions of reading the smart contract)
	// In order to confirm fairness of dividends distribution the validating interface with open source code is used (the open version is available at https://smartroulette.io/dividends)
	// The source code is available at the address https://github.com/Smartroulette/SmartRouletteDividends
	function send_DividendToAddress(address holder, uint256 amount) isManager 
	{
		uint256 avgGasValue = 30000;
		if (amount < avgGasValue * tx.gasprice) throw;
		if(holder.send(amount - avgGasValue * tx.gasprice) == false) throw;	
	}

	function () payable
	{
		if(smartToken.gameListOf(msg.sender))
		{
			// only the one game can be attached to this contract
			if (gameAddress == 0) 
				gameAddress = msg.sender;
			else if (gameAddress != msg.sender)
				throw;

			// do not send new payment until previous is done
			if (dividendHistory.length > 0 && dividendHistory[dividendHistory.length - 1].AllPaymentsSent == false) throw;

			dividendHistory.push(DividendInfo(msg.value, block.number, false));			
		}
		else 
		{
			throw;
		}
	}
}