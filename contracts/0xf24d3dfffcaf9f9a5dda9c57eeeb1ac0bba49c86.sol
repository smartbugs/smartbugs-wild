/**
 * The Xmas Token contract complies with the ERC20 standard (see https://github.com/ethereum/EIPs/issues/20).
 * Santa Claus doesn't kepp any shares and all tokens not being sold during the crowdsale (but the 
 * reserved gift shares) are burned by the elves.
 * 
 * Author: Christmas Elf
 * Audit: Rudolf the red nose Reindear
 */

pragma solidity ^0.4.15;

/**
 * Defines functions that provide safe mathematical operations.
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal returns(uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal returns(uint256) {
		uint256 c = a / b;
		return c;
	}

	function sub(uint256 a, uint256 b) internal returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal returns(uint256) {
		uint256 c = a + b;
		assert(c >= a && c >= b);
		return c;
	}
}

/**
 * Implementation of Xmas Token contract.
 */
contract XmasToken {
    
    using SafeMath for uint256; 
	
	// Xmas token basic data
	string constant public standard = "ERC20";
	string constant public symbol = "xmas";
	string constant public name = "XmasToken";
	uint8 constant public decimals = 18;
	
	// Xmas token distribution
	uint256 constant public initialSupply = 4000000 * 1 ether;
	uint256 constant public tokensForIco = 3000000 * 1 ether;
	uint256 constant public tokensForBonus = 1000000 * 1 ether;
	
	/** 
	 * Starting with this time tokens may be transfered.
	 */
	uint256 constant public startAirdropTime = 1514073600;
	
	/** 
	 * Starting with this time tokens may be transfered.
	 */
	uint256 public startTransferTime;
	
	/**
	 * Number of tokens sold in crowdsale
	 */
	uint256 public tokensSold;

	/**
	 * true if tokens have been burned
	 */
	bool public burned;

	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;
	
	// -------------------- Crowdsale parameters --------------------
	
	/**
	 * the start date of the crowdsale 
	 */
	uint256 constant public start = 1510401600;
	
	/**
	 * the end date of the crowdsale 
	 */
	uint256 constant public end = 1512863999;

	/**
	 * the exchange rate: 1 eth = 1000 xmas tokens
	 */
	uint256 constant public tokenExchangeRate = 1000;
	
	/**
	 * how much has been raised by crowdale (in ETH) 
	 */
	uint256 public amountRaised;

	/**
	 * indicates if the crowdsale has been closed already 
	 */
	bool public crowdsaleClosed = false;

	/**
	 * tokens will be transfered from this address 
	 */
	address public xmasFundWallet;
	
	/**
	 * the wallet on which the eth funds will be stored 
	 */
	address ethFundWallet;
	
	// -------------------- Events --------------------
	
	// public events on the blockchain that will notify listeners
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed _owner, address indexed spender, uint256 value);
	event FundTransfer(address backer, uint amount, bool isContribution, uint _amountRaised);
	event Burn(uint256 amount);

	/** 
	 * Initializes contract with initial supply tokens to the creator of the contract 
	 */
	function XmasToken(address _ethFundWallet) {
		ethFundWallet = _ethFundWallet;
		xmasFundWallet = msg.sender;
		balanceOf[xmasFundWallet] = initialSupply;
		startTransferTime = end;
	}
		
	/**
	 * Default function called whenever anyone sends funds to this contract.
	 * Only callable if the crowdsale started and hasn't been closed already and the tokens for icos haven't been sold yet.
	 * The current token exchange rate is looked up and the corresponding number of tokens is transfered to the receiver.
	 * The sent value is directly forwarded to a safe wallet.
	 * This method allows to purchase tokens in behalf of another address.
	 */
	function() payable {
		uint256 amount = msg.value;
		uint256 numTokens = amount.mul(tokenExchangeRate); 
		require(numTokens >= 100 * 1 ether);
		require(!crowdsaleClosed && now >= start && now <= end && tokensSold.add(numTokens) <= tokensForIco);

		ethFundWallet.transfer(amount);
		
		balanceOf[xmasFundWallet] = balanceOf[xmasFundWallet].sub(numTokens); 
		balanceOf[msg.sender] = balanceOf[msg.sender].add(numTokens);

		Transfer(xmasFundWallet, msg.sender, numTokens);

		// update status
		amountRaised = amountRaised.add(amount);
		tokensSold += numTokens;

		FundTransfer(msg.sender, amount, true, amountRaised);
	}
	
	/** 
	 * Sends the specified amount of tokens from msg.sender to a given address.
	 * @param _to the address to transfer to.
	 * @param _value the amount of tokens to be trasferred.
	 * @return true if the trasnfer is successful, false otherwise.
	 */
	function transfer(address _to, uint256 _value) returns(bool success) {
		require(now >= startTransferTime); 

		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value); 
		balanceOf[_to] = balanceOf[_to].add(_value); 

		Transfer(msg.sender, _to, _value); 

		return true;
	}

	/** 
	 * Allows another contract or person to spend the specified amount of tokens on behalf of msg.sender.
	 * @param _spender the address which will spend the funds.
	 * @param _value the amount of tokens to be spent.
	 * @return true if the approval is successful, false otherwise.
	 */
	function approve(address _spender, uint256 _value) returns(bool success) {
		require((_value == 0) || (allowance[msg.sender][_spender] == 0));

		allowance[msg.sender][_spender] = _value;

		Approval(msg.sender, _spender, _value);

		return true;
	}

	/** 
	 * Transfers tokens from one address to another address.
	 * This is only allowed if the token holder approves. 
	 * @param _from the address from which the given _value will be transfer.
	 * @param _to the address to which the given _value will be transfered.
	 * @param _value the amount of tokens which will be transfered from one address to another.
	 * @return true if the transfer was successful, false otherwise. 
	 */
	function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
		if (now < startTransferTime) 
			require(_from == xmasFundWallet);
		var _allowance = allowance[_from][msg.sender];
		require(_value <= _allowance);
		
		balanceOf[_from] = balanceOf[_from].sub(_value); 
		balanceOf[_to] = balanceOf[_to].add(_value); 
		allowance[_from][msg.sender] = _allowance.sub(_value);

		Transfer(_from, _to, _value);

		return true;
	}
	
	/** 
	 * Burns the remaining tokens except the gift share.
	 * To be called when ICO is closed. Anybody may burn the tokens after ICO ended, but only once.
	 */
	function burn() internal {
		require(now > startTransferTime);
		require(burned == false);
			
		uint256 difference = balanceOf[xmasFundWallet].sub(tokensForBonus);
		tokensSold = tokensForIco.sub(difference);
		balanceOf[xmasFundWallet] = tokensForBonus;
			
		burned = true;

		Burn(difference);
	}

	/**
	 * Marks the crowdsale as closed.
	 * Burns the unsold tokens, if any.
	 */
	function markCrowdsaleEnding() {
		require(now > end);

		burn(); 
		crowdsaleClosed = true;
	}
	
	/**
	 * Sends the bonus tokens to addresses from Santa's list gift.
	 * @return true if the airdrop is successful, false otherwise.
	 */
	function sendGifts(address[] santaGiftList) returns(bool success)  {
		require(msg.sender == xmasFundWallet);
		require(now >= startAirdropTime);
	
		for(uint i = 0; i < santaGiftList.length; i++) {
		    uint256 tokensHold = balanceOf[santaGiftList[i]];
			if (tokensHold >= 100 * 1 ether) { 
				uint256 bonus = tokensForBonus.div(1 ether);
				uint256 giftTokens = ((tokensHold.mul(bonus)).div(tokensSold)) * 1 ether;
				transferFrom(xmasFundWallet, santaGiftList[i], giftTokens);
			}
		}
		
		return true;
	}
}